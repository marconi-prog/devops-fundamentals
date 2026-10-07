package com.marconi.devops.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record TaskRequest(

        @NotBlank(message = "Title must not be blank")
        @Size(min = 3, max = 100, message = "Title must be between 3 and 100 characters")
        String title,

        @Size(max = 500, message = "Description must have at most 500 characters")
        String description,

        boolean completed
) {
}
