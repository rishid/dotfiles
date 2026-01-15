# Code Quality Guidelines

## Code Quality Standards

YOU MUST: Write clear, maintainable code with proper documentation
YOU MUST: Follow established coding conventions for the project's language
YOU MUST: Include appropriate error handling
YOU MUST: Write meaningful variable and function names

## Fundamental Design Principles

YOU MUST: Adhere to these core principles:

- **DRY (Don't Repeat Yourself)**: Eliminate code duplication
- **YAGNI (You Aren't Gonna Need It)**: Implement only what's needed
- **KISS (Keep It Simple, Stupid)**: Favor simplicity over complexity
- **SOLID Principles**:
  - Single Responsibility Principle: Each function/class should have one reason to change
  - Open/Closed Principle: Open for extension, closed for modification
  - Liskov Substitution Principle: Derived classes must be substitutable for base classes
  - Interface Segregation Principle: Don't force clients to depend on unused interfaces
  - Dependency Inversion Principle: Depend on abstractions, not concretions

## Error Handling and Debugging

NEVER: Use quick fixes or workarounds for errors
NEVER: Comment out error-causing code without proper resolution
NEVER: Silence errors with empty catch blocks
NEVER: Modify test cases to make them pass instead of fixing the underlying issue
NEVER: Use temporary patches that don't address root causes

YOU MUST: Investigate and understand the root cause of errors
YOU MUST: Implement proper, sustainable solutions
YOU MUST: If unsure about the best approach, ask the user for guidance
YOU MUST: Preserve the integrity of existing test cases unless explicitly
instructed otherwise

## Information Gathering

YOU MUST: Actively use web search when encountering:

- Unfamiliar libraries, frameworks, or technologies
- API documentation needs
- Best practices for specific implementations
- Error messages or debugging guidance
- Latest syntax or feature updates

IMPORTANT: Don't assume knowledge about rapidly changing technologies
YOU MUST: Always verify implementation details with current documentation when uncertain

## Research Limitations and Reporting

YOU MUST: When research is insufficient or yields no results:

- Report specific research attempts made and their outcomes
- State clearly what information could not be found
- Explain why the research was insufficient
- Ask user for additional information or guidance
- NEVER: Continue with incomplete or uncertain information
- NEVER: Fill gaps with assumptions or best guesses
