# ClefCraft - Superhero Music Quiz 🦸‍♂️🎵

ClefCraft is a vibrant, interactive Flutter application designed to help users learn musical notes on the treble clef. It features a highly stylized **Comic Book / Superhero aesthetic** with dynamic visual and audio feedback.

## Live Demo 🌐

Check out the live application here: **[https://sebastian-nasuta.github.io/clef-craft/](https://sebastian-nasuta.github.io/clef-craft/)**

## Features 🚀

- **Interactive Note Quiz**: Learn to identify notes on the musical staff.
- **Superhero Visuals**:
  - **Success**: A "Sweet Note" effect where colorful musical symbols fly out.
  - **Incorrect Answer**: A "Radial Hellfire" explosion that engulfs the button.
- **Immersive Sound Effects**:
  - **Success**: A happy C-Major arpeggio synthesised specifically for this project.
  - **Fire**: A realistic crackling and rumbling fire sound for incorrect guesses.
- **Glassmorphism UI**: A modern, high-contrast dark theme with translucent elements.
- **Dynamic Background**: Custom-generated superhero-themed background.

## Technology Stack 🛠️

- **Flutter**: Cross-platform framework.
- **Google Fonts (Bangers)**: For that classic comic book typography.
- **Audioplayers**: For high-quality sound feedback.
- **Custom Painters**: Most visual effects (notes, staff, fire, etc.) are drawn directly on the canvas using Flutter's `CustomPainter`.

## Getting Started 🏁

### Prerequisites

- Flutter SDK (Latest Stable)
- Chrome (for web development)

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/sebastian-nasuta/clef-craft.git
   ```
2. Navigate to the project directory:
   ```bash
   cd clef_craft
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run -d chrome
   ```

## Visual Effects Details 🎨

- **Hellfire**: Uses a custom particle system with 300+ particles, additive blending, and heat gradients to create an organic fireball effect.
- **Sweet Notes**: Radial explosion of musical symbols (♩, ♪, ♫, ♬, ♭, ♯) with bold outlines and pop-art colors.
- **Screen Shake**: Impact feedback on correct answers using a dedicated `Shaker` widget.

---
Created by Sebastian Nasuta with Antigravity 🚀
