import type { Task } from "meilisearch";

/*
 * The meilisearch SDK (<= 0.49.0) Task constructor wraps nullable timestamps
 * with `new Date()` unconditionally, turning server-side `null` into the epoch
 * time `1970-01-01T00:00:00.000Z`. Normalize those fields back to null so
 * unfinished tasks (enqueued / processing) keep their null timestamps.
 */
export type NormalizedTask = Omit<Task, "startedAt" | "finishedAt"> & {
	startedAt: Date | null;
	finishedAt: Date | null;
};

const isEpochDate = (date: Date | string | null | undefined): boolean => {
	return date instanceof Date && date.getTime() === 0;
};

export const normalizeTask = (task: Task): NormalizedTask => {
	return {
		...task,
		startedAt: isEpochDate(task.startedAt) ? null : task.startedAt,
		finishedAt: isEpochDate(task.finishedAt) ? null : task.finishedAt,
	};
};
