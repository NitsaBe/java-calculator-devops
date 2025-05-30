package com.calculator.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(CalculatorController.class)
public class CalculatorControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    public void testIndexPage() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(view().name("calculator"));
    }

    @Test
    public void testAddition() throws Exception {
        mockMvc.perform(post("/calculate")
                        .param("num1", "5")
                        .param("num2", "3")
                        .param("operation", "add"))
                .andExpect(status().isOk())
                .andExpect(model().attribute("result", 8.0));
    }

    @Test
    public void testDivisionByZero() throws Exception {
        mockMvc.perform(post("/calculate")
                        .param("num1", "5")
                        .param("num2", "0")
                        .param("operation", "divide"))
                .andExpect(status().isOk())
                .andExpect(model().attribute("error", "Cannot divide by zero"));
    }
}