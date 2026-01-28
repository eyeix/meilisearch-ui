"use client";
import { useCurrentInstance } from "@/hooks/useCurrentInstance";
import { useIndexTaskCounts } from "@/hooks/useIndexTaskCounts";
import { useInstanceStats } from "@/hooks/useInstanceStats";
import { cn } from "@/lib/cn";
import { Input } from "@arco-design/web-react";
import { Button, Pagination, Tag, Tooltip } from "@douyinfe/semi-ui";
import { Card, CardBody, CardHeader } from "@nextui-org/react";
import { IconAlertTriangle } from "@tabler/icons-react";
import { Link, useNavigate } from "@tanstack/react-router";
import Fuse from "fuse.js";
import _ from "lodash";
import type { MeiliSearch } from "meilisearch";
import { type FC, useEffect, useMemo } from "react";
import { useTranslation } from "react-i18next";
import { useImmer } from "use-immer";
import { EmptyArea } from "../common/empty";
import { LoaderPage } from "../common/Loader";
import { CreateIndexButton } from "./CreateIndex";

interface Props {
	className?: string;
	client: MeiliSearch;
}

interface IndexItem {
	uid: string;
	fields: string[];
	numberOfDocuments: number;
	isIndexing: boolean;
	href: string;
	documentsHref: string;
}

const fuse = new Fuse<IndexItem>([], {
	keys: ["uid", "fields"],
	includeMatches: false,
	includeScore: true,
	shouldSort: true,
});

export const IndexList: FC<Props> = ({ className = "", client }) => {
	const navigate = useNavigate();
	const { t } = useTranslation("index");
	const currentInstance = useCurrentInstance();
	const [stats, statsQuery] = useInstanceStats(client);
	const indexList = useMemo(() => {
		return Object.entries(stats?.indexes || {}).map(([uid, index]) => ({
			uid,
			fields: Object.keys(index.fieldDistribution),
			numberOfDocuments: index.numberOfDocuments,
			isIndexing: index.isIndexing,
			href: `/ins/${currentInstance.id}/index/${uid}`,
			documentsHref: `/ins/${currentInstance.id}/index/${uid}/documents`,
		}));
	}, [stats?.indexes, currentInstance.id]);

	// Get task counts for all indexes
	const indexUids = useMemo(
		() => indexList.map((item) => item.uid),
		[indexList],
	);
	const [taskCounts] = useIndexTaskCounts(client, indexUids);

	useEffect(() => {
		// load index list into fuse collection
		if (stats?.indexes) {
			fuse.setCollection(indexList);
		}
	}, [stats?.indexes, indexList]);

	const [state, updateState] = useImmer({
		offset: 0,
		limit: 24,
		query: "",
	});

	const filteredData = useMemo(() => {
		// empty string cause fuse.search return empty array.
		if (state.query && state.query.trim().length > 0) {
			return fuse.search(state.query).map((d) => d.item) || [];
		}
		return indexList || [];
	}, [indexList, state.query]);

	const pagination = useMemo(() => {
		return {
			currentPage: state.offset / state.limit + 1,
			totalPage: _.ceil((filteredData.length || 0) / state.limit),
		};
	}, [filteredData.length, state.limit, state.offset]);

	const paginatedData = useMemo(() => {
		return filteredData.slice(state.offset, state.offset + state.limit);
	}, [filteredData, state.offset, state.limit]);

	const isLoading = useMemo(() => {
		return statsQuery.isLoading || statsQuery.isFetching;
	}, [statsQuery.isLoading, statsQuery.isFetching]);

	return useMemo(
		() => (
			<div className={cn("flex flex-col gap-y-2 flex-1", className)}>
				<div className="flex items-center gap-4">
					<div className="text-2xl font-bold text-nowrap">
						{t("common:indexes")}
					</div>
					<Tooltip content={t("search.tip")}>
						<div className="ml-auto !w-60">
							<Input.Search
								placeholder={t("common:search")}
								defaultValue=""
								onChange={(v) =>
									updateState((d) => {
										d.query = v;
									})
								}
							/>
						</div>
					</Tooltip>
					<CreateIndexButton afterMutation={() => statsQuery.refetch()} />
				</div>
				{paginatedData && paginatedData.length > 0 ? (
					<div className="grid grid-cols-6 gap-5 place-content-start place-items-start py-3">
						{paginatedData?.map((item) => {
							return (
								<Card
									key={item.uid}
									fullWidth
									shadow="sm"
									className="col-span-3 laptop:col-span-2 hover:no-underline h-fit hover:outline-primary-400/80 outline outline-2 outline-transparent"
								>
									<CardHeader as={Link} to={item.href}>
										<div className="text-xl px-1">{item.uid}</div>
									</CardHeader>
									<CardBody className="space-y-1">
										<div className="flex items-center justify-between gap-2">
											<div className="flex gap-2 flex-1 min-w-0">
												<Tooltip content={t("count_tooltip")}>
													<Link
														to={item.documentsHref}
														className="no-underline"
													>
														<Tag
															size="small"
															color="cyan"
															className={
																"flex-shrink-0 cursor-pointer hover:opacity-80 transition-opacity"
															}
														>
															{t("count")}: {item.numberOfDocuments ?? 0}
														</Tag>
													</Link>
												</Tooltip>
												{item.isIndexing && (
													<Tooltip content={t("indexing_tip")}>
														<Tag
															color="amber"
															size="small"
															className={"flex flex-nowrap flex-shrink-0"}
														>
															<IconAlertTriangle size={"1em"} />
															<div>{t("indexing")}...</div>
														</Tag>
													</Tooltip>
												)}
											</div>
											<div className="flex gap-2 flex-shrink-0">
												<Tooltip content={t("settings")}>
													<Button
														theme="light"
														type="warning"
														icon={
															<div className="i-lucide:settings w-1em h-1em" />
														}
														size="small"
														onClick={() =>
															navigate({
																to: `index/${item.uid}/setting`,
																from: "/ins/$insID",
															})
														}
													/>
												</Tooltip>
												<Tooltip
													content={
														taskCounts[item.uid] > 0
															? t("tasks_count_tooltip", {
																	count: taskCounts[item.uid],
																})
															: t("tasks")
													}
												>
													<div className="relative flex items-center">
														<Button
															theme="light"
															type="primary"
															icon={
																<div className="i-lucide:workflow w-1em h-1em" />
															}
															size="small"
															onClick={() =>
																navigate({
																	to: "tasks",
																	search: { indexUids: [item.uid] },
																	from: "/ins/$insID",
																})
															}
														/>
														{taskCounts[item.uid] > 0 && (
															<span
																className="absolute top-0 right-0 translate-x-1/2 -translate-y-1/2 bg-red-500 text-white text-xs font-bold rounded-full min-w-[1.25rem] h-5 flex items-center justify-center px-1 z-10"
																title={t("tasks_count", {
																	count: taskCounts[item.uid],
																})}
															>
																{taskCounts[item.uid] > 99
																	? "99+"
																	: taskCounts[item.uid]}
															</span>
														)}
													</div>
												</Tooltip>
											</div>
										</div>
									</CardBody>
								</Card>
							);
						})}
					</div>
				) : isLoading ? (
					<LoaderPage />
				) : (
					<EmptyArea />
				)}
				<div className="flex justify-center">
					<Pagination
						pageSize={state.limit}
						total={filteredData.length}
						currentPage={pagination.currentPage}
						onPageChange={(c) => {
							updateState((d) => {
								d.offset = (c - 1) * state.limit;
							});
							statsQuery.refetch();
						}}
					/>
				</div>
			</div>
		),
		[
			className,
			filteredData,
			paginatedData,
			navigate,
			pagination.currentPage,
			state.limit,
			t,
			updateState,
			statsQuery.refetch,
			isLoading,
			taskCounts,
		],
	);
};
