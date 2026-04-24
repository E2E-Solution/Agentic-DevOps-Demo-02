import { v4 as uuidv4 } from "uuid";
import { Task, CreateTaskInput, UpdateTaskInput } from "./task";

class TaskStore {
  private tasks: Map<string, Task> = new Map();

  getAll(): Task[] {
    return Array.from(this.tasks.values()).sort((a, b) =>
      b.createdAt.localeCompare(a.createdAt)
    );
  }

  getById(id: string): Task | undefined {
    return this.tasks.get(id);
  }

  create(input: CreateTaskInput): Task {
    const now = new Date().toISOString();
    const task: Task = {
      id: uuidv4(),
      title: input.title,
      description: input.description,
      status: input.status ?? "todo",
      priority: input.priority ?? "medium",
      createdAt: now,
      updatedAt: now,
    };
    this.tasks.set(task.id, task);
    return task;
  }

  update(id: string, input: UpdateTaskInput): Task | undefined {
    const existing = this.tasks.get(id);
    if (!existing) {
      return undefined;
    }
    const updated: Task = { ...existing, updatedAt: new Date().toISOString() };
    if (input.title !== undefined) updated.title = input.title;
    if (input.description !== undefined) updated.description = input.description;
    if (input.status !== undefined) updated.status = input.status;
    if (input.priority !== undefined) updated.priority = input.priority;
    this.tasks.set(id, updated);
    return updated;
  }

  delete(id: string): boolean {
    return this.tasks.delete(id);
  }

  clear(): void {
    this.tasks.clear();
  }
}

export const taskStore = new TaskStore();

// Seed data for development/demo purposes (skipped during tests)
if (process.env.NODE_ENV !== "test") {
  taskStore.create({
    title: "Set up project scaffolding",
    description: "Initialize the Node.js/TypeScript project with Express and configure build tooling.",
    status: "done",
    priority: "high",
  });

  taskStore.create({
    title: "Implement task CRUD endpoints",
    description: "Build REST API routes for creating, reading, updating, and deleting tasks.",
    status: "in-progress",
    priority: "high",
  });

  taskStore.create({
    title: "Write API documentation",
    description: "Document all endpoints with request/response examples in the README.",
    status: "todo",
    priority: "medium",
  });
}
