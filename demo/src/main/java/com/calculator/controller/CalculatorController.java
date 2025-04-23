package com.example.calculator.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class CalculatorController {

    @GetMapping("/")
    public String showCalculatorForm(Model model) {
        model.addAttribute("result", "");
        return "calculator";
    }

    @PostMapping("/calculate")
    public String calculate(
            @RequestParam("firstNumber") double firstNumber,
            @RequestParam("secondNumber") double secondNumber,
            @RequestParam("operation") String operation,
            Model model) {

        double result = 0;

        switch (operation) {
            case "add":
                result = firstNumber + secondNumber;
                break;
            case "subtract":
                result = firstNumber - secondNumber;
                break;
            case "multiply":
                result = firstNumber * secondNumber;
                break;
            case "divide":
                if (secondNumber != 0) {
                    result = firstNumber / secondNumber;
                } else {
                    model.addAttribute("error", "Cannot divide by zero");
                    model.addAttribute("result", "Error");
                    return "calculator";
                }
                break;
        }

        model.addAttribute("result", result);
        model.addAttribute("firstNumber", firstNumber);
        model.addAttribute("secondNumber", secondNumber);
        model.addAttribute("operation", operation);

        return "calculator";
    }
}