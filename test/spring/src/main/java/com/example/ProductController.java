package com.example;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @GetMapping
    public String getAllProducts() {
        return "Get all products";
    }

    @GetMapping("/search")
    public String searchProducts(@RequestParam String q) {
        return "Search products: " + q;
    }

    @PostMapping
    public String createProduct(@RequestBody String product) {
        return "Create product";
    }
}