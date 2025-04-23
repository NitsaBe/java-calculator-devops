package com.example.calculator.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorServiceTest {

    private final CalculatorService calculatorService = new CalculatorService();

    @Test
    @DisplayName("Test addition operation")
    void testAdd() {
        assertEquals(5, calculatorService.add(2, 3));
        assertEquals(0, calculatorService.add(0, 0));
        assertEquals(-1, calculatorService.add(2, -3));
    }

    @Test
    @DisplayName("Test subtraction operation")
    void testSubtract() {
        assertEquals(-1, calculatorService.subtract(2, 3));
        assertEquals(5, calculatorService.subtract(8, 3));
        assertEquals(0, calculatorService.subtract(3, 3));
    }

    @Test
    @DisplayName("Test multiplication operation")
    void testMultiply() {
        assertEquals(6, calculatorService.multiply(2, 3));
        assertEquals(0, calculatorService.multiply(0, 5));
        assertEquals(-6, calculatorService.multiply(2, -3));
    }

    @Test
    @DisplayName("Test division operation")
    void testDivide() {
        assertEquals(2, calculatorService.divide(6, 3));
        assertEquals(0.5, calculatorService.divide(1, 2));
    }

    @Test
    @DisplayName("Test division by zero")
    void testDivideByZero() {
        assertThrows(ArithmeticException.class, () -> calculatorService.divide(5, 0));
    }
}