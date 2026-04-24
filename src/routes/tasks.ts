import { Router, Request, Response } from "express";
import { taskStore } from "../models/taskStore";

const router = Router();

// GET /api/tasks — List all tasks
router.get("/tasks", (_req: Request, res: Response) => {
  const tasks = taskStore.getAll();
  res.json({ data: tasks, count: tasks.length });
});

// GET /api/tasks/:id — Get a single task by ID
router.get("/tasks/:id", (req: Request, res: Response) => {
  const task = taskStore.getById(req.params.id);
  if (!task) {
    res.status(404).json({
      error: {
        code: "NOT_FOUND",
        message: `Task with id '${req.params.id}' not found`,
      },
    });
    return;
  }
  res.json({ data: task });
});

// POST /api/tasks — Create a new task
router.post("/tasks", (req: Request, res: Response) => {
  const { title, description, status, priority } = req.body;
  const task = taskStore.create({ title, description, status, priority });
  res.status(201).json({ data: task });
});

// PUT /api/tasks/:id — Update an existing task
router.put("/tasks/:id", (req: Request, res: Response) => {
  const { title, description, status, priority } = req.body;
  const task = taskStore.update(req.params.id, { title, description, status, priority });
  if (!task) {
    res.status(404).json({
      error: {
        code: "NOT_FOUND",
        message: `Task with id '${req.params.id}' not found`,
      },
    });
    return;
  }
  res.json({ data: task });
});

// DELETE /api/tasks/:id — Delete a task
router.delete("/tasks/:id", (req: Request, res: Response) => {
  const deleted = taskStore.delete(req.params.id);
  if (!deleted) {
    res.status(404).json({
      error: {
        code: "NOT_FOUND",
        message: `Task with id '${req.params.id}' not found`,
      },
    });
    return;
  }
  res.status(204).send();
});

export default router;
