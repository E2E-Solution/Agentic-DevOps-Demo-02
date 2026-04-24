import { describe, it, expect, beforeEach } from "vitest";
import request from "supertest";
import app from "../index";
import { taskStore } from "../models/taskStore";

beforeEach(() => {
  taskStore.clear();
});

describe("GET /api/tasks", () => {
  it("returns empty list when no tasks exist", async () => {
    const res = await request(app).get("/api/tasks");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ data: [], count: 0 });
  });

  it("returns all tasks with count", async () => {
    taskStore.create({ title: "Task 1", description: "Desc 1" });
    taskStore.create({ title: "Task 2", description: "Desc 2" });
    const res = await request(app).get("/api/tasks");
    expect(res.status).toBe(200);
    expect(res.body.count).toBe(2);
    expect(res.body.data).toHaveLength(2);
  });
});

describe("GET /api/tasks/:id", () => {
  it("returns the task when found", async () => {
    const task = taskStore.create({ title: "My task", description: "Details" });
    const res = await request(app).get(`/api/tasks/${task.id}`);
    expect(res.status).toBe(200);
    expect(res.body.data.id).toBe(task.id);
    expect(res.body.data.title).toBe("My task");
  });

  it("returns 404 with error body when not found", async () => {
    const res = await request(app).get("/api/tasks/nonexistent-id");
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("NOT_FOUND");
    expect(res.body.error.message).toContain("nonexistent-id");
  });
});

describe("POST /api/tasks", () => {
  it("creates a task and returns 201 with the created task", async () => {
    const res = await request(app).post("/api/tasks").send({
      title: "New task",
      description: "New desc",
      status: "todo",
      priority: "high",
    });
    expect(res.status).toBe(201);
    expect(res.body.data.title).toBe("New task");
    expect(res.body.data.id).toBeDefined();
    expect(res.body.data.status).toBe("todo");
    expect(res.body.data.priority).toBe("high");
  });

  it("applies default status and priority when not provided", async () => {
    const res = await request(app).post("/api/tasks").send({
      title: "Minimal task",
      description: "Minimal desc",
    });
    expect(res.status).toBe(201);
    expect(res.body.data.status).toBe("todo");
    expect(res.body.data.priority).toBe("medium");
  });
});

describe("PUT /api/tasks/:id", () => {
  it("updates the task and returns 200 with updated data", async () => {
    const task = taskStore.create({ title: "Original", description: "Orig desc" });
    const res = await request(app)
      .put(`/api/tasks/${task.id}`)
      .send({ title: "Updated", status: "done" });
    expect(res.status).toBe(200);
    expect(res.body.data.title).toBe("Updated");
    expect(res.body.data.status).toBe("done");
    expect(res.body.data.description).toBe("Orig desc");
  });

  it("returns 404 when task not found", async () => {
    const res = await request(app).put("/api/tasks/missing-id").send({ title: "X" });
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("NOT_FOUND");
  });
});

describe("DELETE /api/tasks/:id", () => {
  it("deletes the task and returns 204 with no body", async () => {
    const task = taskStore.create({ title: "To delete", description: "Bye" });
    const res = await request(app).delete(`/api/tasks/${task.id}`);
    expect(res.status).toBe(204);
    expect(res.text).toBe("");
  });

  it("returns 404 when task not found", async () => {
    const res = await request(app).delete("/api/tasks/ghost-id");
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("NOT_FOUND");
  });
});
