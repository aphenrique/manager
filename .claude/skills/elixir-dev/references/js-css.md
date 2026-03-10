# JS e CSS Guidelines

## Tailwind CSS v4

- Tailwind v4 **no longer needs** `tailwind.config.js` — uses new import syntax in `app.css`:

      @import "tailwindcss" source(none);
      @source "../css";
      @source "../js";
      @source "../../lib/my_app_web";

- **Always use and maintain** this import syntax in `app.css` for projects generated with `phx.new`
- **Never** use `@apply` when writing raw CSS
- **Always** manually write Tailwind-based components — do not use daisyUI for UI components (project uses daisyUI only for `data-theme="dark"` on `<html>`)

## Assets Bundle

- Out of the box **only `app.js` and `app.css` bundles are supported**
- You cannot reference external vendor `src` or `href` in layouts
- Import vendor deps into `app.js` and `app.css` to use them
- **Never write inline `<script>custom js</script>` tags within templates**

## UI/UX

- Produce world-class UI designs with focus on usability, aesthetics, and modern design
- Implement subtle micro-interactions (button hover effects, smooth transitions)
- Ensure clean typography, spacing, and layout balance
- Focus on delightful details: hover effects, loading states, smooth page transitions
