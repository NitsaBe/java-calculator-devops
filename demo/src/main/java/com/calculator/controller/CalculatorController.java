public class CalculatorController {

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("result", "");
        return "calculator";
    }

    @PostMapping("/calculate")
    public String calculate(
            @RequestParam("num1") double num1,
            @RequestParam("num2") double num2,
            @RequestParam("operation") String operation,
            Model model) {

        double result = 0;

        switch (operation) {
            case "add":
                result = num1 + num2;
                break;
            case "subtract":
                result = num1 - num2;
                break;
            case "multiply":
                result = num1 * num2;
                break;
            case "divide":
                if (num2 != 0) {
                    result = num1 / num2;
                } else {
                    model.addAttribute("error", "Cannot divide by zero");
                    model.addAttribute("result", "Error");
                    return "calculator";
                }
                break;
        }

        model.addAttribute("result", result);
        return "calculator";
    }
}