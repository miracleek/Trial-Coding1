---
name: Luminous Finance
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#38393a'
  surface-container-lowest: '#0c0f0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#282a2b'
  surface-container-highest: '#333535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#c0caad'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#8a947a'
  outline-variant: '#414a34'
  surface-tint: '#8cdc00'
  primary: '#ffffff'
  on-primary: '#1f3700'
  primary-container: '#a0fb00'
  on-primary-container: '#457000'
  inverse-primary: '#416900'
  secondary: '#c8c6c5'
  on-secondary: '#313030'
  secondary-container: '#474746'
  on-secondary-container: '#b7b5b4'
  tertiary: '#ffffff'
  on-tertiary: '#68000b'
  tertiary-container: '#ffdad7'
  on-tertiary-container: '#c31f29'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#a0fb00'
  primary-fixed-dim: '#8cdc00'
  on-primary-fixed: '#102000'
  on-primary-fixed-variant: '#304f00'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ae'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#930014'
  background: '#121414'
  on-background: '#e2e2e2'
  surface-variant: '#333535'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-bold:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '700'
    lineHeight: '1.2'
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.2'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  sidebar-width: 260px
  container-padding: 2rem
  stack-gap: 1.5rem
  grid-gutter: 1rem
  base-unit: 4px
---

## Brand & Style

This design system targets modern professionals and tech-savvy individuals who view financial management as an empowering, high-performance activity. The aesthetic is a hybrid of **Corporate Modern** and **High-Contrast Bold**, creating an environment that feels both disciplined and energetic.

The visual narrative is built on the contrast between a deep, "obsidian" dark mode foundation and a high-energy "Electric Lime" accent. This juxtaposition suggests clarity in the dark—turning complex data into actionable insights. The interface should evoke a sense of precision, speed, and absolute control over one's capital.

## Colors

The palette is anchored by **Electric Lime (#a3ff00)**, used strategically for primary actions, active states, and positive financial trends. This is contrasted against a **Pitch Black** sidebar and a **Soft Grey** main content area to reduce eye strain while maintaining a high-end feel.

- **Success/Primary:** Electric Lime for growth and "Add" actions.
- **Danger/Expense:** Vibrant Red (#ff4d4d) for outflows and warnings.
- **Neutral/Surface:** A range of greys from deep charcoal for dark elements to off-white for light-mode cards, ensuring readability across all elevations.
- **Deep Emerald:** A dark, desaturated green (#122b22) is used for secondary buttons to provide a sophisticated alternative to pure black or grey.

## Typography

This design system utilizes **Plus Jakarta Sans** for headlines to provide a modern, slightly geometric personality that feels premium and welcoming. Its bold weights are particularly effective for financial totals and large display text.

For functional UI elements, data tables, and long-form text, **Inter** is used for its exceptional legibility and neutral, systematic character. 

**Key Rules:**
- Use **Headline-XL** with tight letter-spacing for hero statements and primary balances.
- **Label-Bold** should be used for section headers within forms (e.g., "TAMBAH PENGELUARAN") to establish a clear hierarchy.
- Numeric data should always use tabular lining figures if available in the font to ensure columns of numbers align perfectly.

## Layout & Spacing

The layout follows a **Fixed Sidebar / Fluid Content** model. The sidebar remains anchored to the left in a high-contrast dark state, while the main dashboard uses a light, airy background to keep data readable.

- **Grid:** A 12-column responsive grid for the main content area.
- **Rhythm:** An 8px linear scale is used for all spacing. 16px (2 units) is the standard padding for cards, while 24px (3 units) is used for major section gaps.
- **Density:** The design maintains a "Medium" density—professional enough to show significant data but with enough whitespace to remain "accessible" and not overwhelming.

## Elevation & Depth

Hierarchy is achieved through **Tonal Layers** and **Low-Contrast Outlines**. 

- **Level 0 (Background):** Solid off-white (#f8f9fa).
- **Level 1 (Cards):** Pure white background with a subtle 1px border (#e9ecef). No heavy shadows are used; instead, a very soft, large-radius ambient shadow (5% opacity) provides a gentle lift.
- **Interactions:** When a card is hovered or an item is selected, it should transition to a slightly thicker border or an Electric Lime left-accent bar to indicate focus.
- **Sidebar:** Uses a "Flat" approach with high-contrast active states (Electric Lime background for the active menu item) rather than depth-based elevation.

## Shapes

The design system employs a **Rounded** shape language. This softens the "industrial" feel of a finance app, making it feel more like a lifestyle tool.

- **Standard Elements:** Buttons, inputs, and small cards use a 0.5rem (8px) radius.
- **Large Containers:** Main dashboard cards and the sidebar active-state "pill" markers use a 1rem (16px) radius for a friendlier, modern appearance.
- **Status Chips:** Use a full "Pill" radius (999px) to distinguish them from functional buttons.

## Components

### Buttons
- **Primary:** Electric Lime (#a3ff00) background with Black text. Bold weight.
- **Secondary:** Deep Emerald (#122b22) background with Electric Lime text.
- **Ghost:** Transparent background with 1px border and high-contrast text.

### Inputs
- **Text Fields:** White background with a light grey border. On focus, the border transitions to a 2px Electric Lime stroke. Labels sit above the field in **Label-Bold** typography.

### Cards & Lists
- **Financial Cards:** Use a left-hand accent border (4px width) colored by category (Green for income, Red for expense) to provide a quick visual scan of transaction types.
- **Summary Tiles:** Large, bold typography for the currency value, paired with a small trend indicator or category icon.

### Navigation
- **Sidebar Links:** High-contrast icons. The active state is a bold Electric Lime "capsule" that spans the width of the sidebar minus margins, ensuring the user's location is unmistakable.

### Additional Components
- **Progress Bars:** Thin, high-contrast bars used for budget tracking (remaining vs. spent).
- **Donut Charts:** Clean, thick strokes with the total balance centered in the middle using **Headline-MD** typography.