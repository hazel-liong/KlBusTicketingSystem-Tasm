# KlBusTicketingSystem-Tasm
 A basic simulation of a real-world bus ticketing system which are implemented in x86 Assembly language TASM.

Language Used: Assembly Language (TASM - Turbo Assembler)

Software Used: GUI Turbo Assembler 5.1

Description: 
The KL Bus Ticketing System is a command-line-based booking platform implemented in assembly language. It allows users to select bus routes, seat types, and additional facilities, calculates the total fare, and provides multiple payment options. It also supports login functionality for concession cardholders to receive discounts.

# Functionalities
User Interaction:
Displays menus for selecting routes, seats, and facilities.
Handles invalid inputs and prompts users to re-enter valid options.

Booking System:
Route options with predefined fares (e.g., Penang, Ipoh, Genting).
Seat types: Standard or Luxury with additional costs.
Additional facilities such as bedding kits, travel insurance, and beverages.

Payment System:
Two payment methods: Cash and Cashless.
Validates payment amounts and calculates change or confirms exact payment.

Membership Discount:
Login system to validate concession cardholders.
Provides a 10% discount to logged-in members.

File Handling:
Reads user credentials from a file for login verification.

User-Friendly Messages:
Clear prompts, error messages, and confirmation outputs.

# Future Improvements
Enhanced User Interface:
Add graphical interface or improve menu aesthetics for better usability.

Dynamic Pricing:
Allow flexible pricing based on real-time data, such as peak hours or demand.

Additional Features:
Enable group bookings, loyalty programs, and refunds.

Error Handling:
Improve robustness by handling more edge cases (e.g., file corruption or incomplete inputs).

Integration with External Systems:
Connect to modern payment gateways for secure transactions.

Portability:
Upgrade the system to work on modern 64-bit platforms using cross-platform tools or languages.