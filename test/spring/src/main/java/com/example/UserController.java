package com.example;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @GetMapping
    public String getAllUsers() {
        return "Get all users";
    }

    @GetMapping("/{id}")
    public String getUserById(@PathVariable Long id) {
        return "Get user by ID: " + id;
    }

    @PostMapping
    public String createUser(@RequestBody String user) {
        return "Create user";
    }

    @PutMapping("/{id}")
    public String updateUser(@PathVariable Long id, @RequestBody String user) {
        return "Update user: " + id;
    }

    @DeleteMapping("/{id}")
    public String deleteUser(@PathVariable Long id) {
        return "Delete user: " + id;
    }

    @PatchMapping("/{id}")
    public String patchUser(@PathVariable Long id, @RequestBody String updates) {
        return "Patch user: " + id;
    }
}