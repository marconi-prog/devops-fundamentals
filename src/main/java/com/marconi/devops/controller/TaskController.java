package com.marconi.devops.controller;

import com.marconi.devops.dto.TaskRequest;
import com.marconi.devops.dto.TaskResponse;
import com.marconi.devops.entity.Task;
import com.marconi.devops.service.TaskService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping
    public List<TaskResponse> findAll() {
        return taskService.findAll()
                .stream()
                .map(TaskResponse::fromEntity)
                .toList();
    }

    @GetMapping("/{id}")
    public TaskResponse findById(@PathVariable Long id) {
        return TaskResponse.fromEntity(
                taskService.findById(id)
        );
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public TaskResponse create(@Valid @RequestBody TaskRequest request) {

        Task task = new Task(
                request.title(),
                request.description()
        );

        task.setCompleted(request.completed());

        return TaskResponse.fromEntity(
                taskService.create(task)
        );
    }

    @PutMapping("/{id}")
    public TaskResponse update(
            @PathVariable Long id,
            @Valid @RequestBody TaskRequest request
    ) {

        Task task = new Task(
                request.title(),
                request.description()
        );

        task.setCompleted(request.completed());

        return TaskResponse.fromEntity(
                taskService.update(id, task)
        );
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        taskService.delete(id);
    }
}