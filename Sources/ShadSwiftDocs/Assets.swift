import Foundation

extension HTMLWriter {
    var css: String {
        """
        /* ShadSwift documentation — the same tokens the library uses, in CSS. */
        :root {
          --background: #ffffff;
          --foreground: #0a0a0a;
          --card: #ffffff;
          --muted: #f7f7f7;
          --muted-foreground: #737373;
          --border: #e6e6e6;
          --primary: #171717;
          --primary-foreground: #fafafa;
          --accent: #f4f4f4;
          --code-bg: #fafafa;
          --radius: 10px;
          --sidebar: 264px;
          --shadow-sm: 0 1px 2px rgba(0,0,0,.06);
          --shadow-md: 0 8px 24px rgba(0,0,0,.08);

          --k: #a626a4;  /* keyword */
          --s: #50a14f;  /* string  */
          --c: #a0a1a7;  /* comment */
          --t: #c18401;  /* type    */
          --m: #4078f2;  /* member  */
          --n: #986801;  /* number  */
        }

        [data-theme="dark"] {
          --background: #0a0a0a;
          --foreground: #fafafa;
          --card: #171717;
          --muted: #1c1c1c;
          --muted-foreground: #a1a1a1;
          --border: #262626;
          --primary: #ededed;
          --primary-foreground: #171717;
          --accent: #222222;
          --code-bg: #121212;
          --shadow-sm: 0 1px 2px rgba(0,0,0,.5);
          --shadow-md: 0 8px 24px rgba(0,0,0,.6);

          --k: #c678dd;
          --s: #98c379;
          --c: #6b7280;
          --t: #e5c07b;
          --m: #61afef;
          --n: #d19a66;
        }

        * { box-sizing: border-box; }

        html { scroll-behavior: smooth; scroll-padding-top: 24px; }

        body {
          margin: 0;
          background: var(--background);
          color: var(--foreground);
          font: 15px/1.6 ui-sans-serif, -apple-system, "SF Pro Text", "Segoe UI", system-ui, sans-serif;
          -webkit-font-smoothing: antialiased;
        }

        a { color: inherit; }

        .skip {
          position: absolute; left: -9999px;
        }
        .skip:focus { left: 8px; top: 8px; background: var(--card); padding: 8px 12px; border-radius: 8px; z-index: 10; }

        .shell {
          display: grid;
          grid-template-columns: var(--sidebar) minmax(0, 1fr);
          max-width: 1360px;
          margin: 0 auto;
        }

        /* ---------- Sidebar ---------- */

        .nav {
          position: sticky;
          top: 0;
          align-self: start;
          height: 100vh;
          overflow-y: auto;
          padding: 24px 20px 48px;
          border-right: 1px solid var(--border);
        }

        .nav__brand {
          display: block;
          font-weight: 640;
          font-size: 16px;
          text-decoration: none;
          letter-spacing: -0.01em;
          margin-bottom: 14px;
        }

        .theme-toggle {
          width: 100%;
          margin-bottom: 22px;
          padding: 6px 10px;
          font: inherit;
          font-size: 12px;
          color: var(--muted-foreground);
          background: var(--card);
          border: 1px solid var(--border);
          border-radius: calc(var(--radius) - 2px);
          cursor: pointer;
          text-align: left;
        }
        .theme-toggle:hover { background: var(--accent); color: var(--foreground); }

        .nav__group {
          margin: 20px 0 6px;
          font-size: 11px;
          font-weight: 600;
          letter-spacing: .06em;
          text-transform: uppercase;
          color: var(--muted-foreground);
        }
        .nav__group:first-child { margin-top: 0; }

        .nav ul { list-style: none; margin: 0; padding: 0; }
        .nav li a {
          display: block;
          padding: 5px 10px;
          margin: 1px 0;
          border-radius: calc(var(--radius) - 2px);
          font-size: 13.5px;
          color: var(--muted-foreground);
          text-decoration: none;
        }
        .nav li a:hover { background: var(--accent); color: var(--foreground); }
        .nav li a.is-active { background: var(--accent); color: var(--foreground); font-weight: 550; }

        /* ---------- Main ---------- */

        .main { padding: 48px 56px 96px; min-width: 0; }

        .page-header { margin-bottom: 40px; }
        .eyebrow {
          margin: 0 0 8px;
          font-size: 11px;
          font-weight: 600;
          letter-spacing: .08em;
          text-transform: uppercase;
          color: var(--muted-foreground);
        }
        h1 { margin: 0 0 12px; font-size: 38px; line-height: 1.15; letter-spacing: -0.025em; font-weight: 660; }
        .lede { margin: 0; max-width: 68ch; font-size: 16.5px; color: var(--muted-foreground); }

        h2 { margin: 0 0 10px; font-size: 20px; letter-spacing: -0.015em; font-weight: 620; }
        h3 { margin: 28px 0 8px; font-size: 15.5px; font-weight: 620; }

        .prose { margin-bottom: 44px; max-width: 74ch; }
        .prose h2 { margin-top: 34px; }
        .prose p { color: var(--muted-foreground); }
        .prose code { font-size: .88em; }

        .group-heading { margin-top: 32px; color: var(--muted-foreground); font-size: 12px; text-transform: uppercase; letter-spacing: .06em; }

        .anchor { text-decoration: none; }
        .anchor:hover::after { content: " #"; color: var(--muted-foreground); font-weight: 400; }

        /* ---------- Examples ---------- */

        .example { margin-bottom: 52px; scroll-margin-top: 24px; }
        .example__head { margin-bottom: 14px; }
        .example__head p { margin: 4px 0 0; color: var(--muted-foreground); font-size: 14px; max-width: 72ch; }

        .preview {
          margin: 0 0 12px;
          padding: 0;
          border: 1px solid var(--border);
          border-radius: var(--radius);
          overflow: hidden;
          background: var(--card);
          box-shadow: var(--shadow-sm);
        }
        .preview__img { display: block; width: 100%; height: auto; }

        /* ---------- Code ---------- */

        .code {
          position: relative;
          border: 1px solid var(--border);
          border-radius: var(--radius);
          background: var(--code-bg);
          overflow: hidden;
        }
        .code pre {
          margin: 0;
          padding: 16px 18px;
          overflow-x: auto;
          font: 12.5px/1.65 ui-monospace, "SF Mono", "JetBrains Mono", Menlo, monospace;
        }
        .code code { white-space: pre; }
        .code__copy {
          position: absolute;
          top: 8px; right: 8px;
          padding: 4px 9px;
          font: inherit;
          font-size: 11px;
          color: var(--muted-foreground);
          background: var(--card);
          border: 1px solid var(--border);
          border-radius: 6px;
          cursor: pointer;
          opacity: 0;
          transition: opacity .12s ease;
        }
        .code:hover .code__copy, .code__copy:focus { opacity: 1; }
        .code__copy:hover { color: var(--foreground); }

        code {
          font-family: ui-monospace, "SF Mono", "JetBrains Mono", Menlo, monospace;
          background: var(--muted);
          padding: .12em .36em;
          border-radius: 5px;
        }
        .code code, pre code { background: none; padding: 0; }

        .k { color: var(--k); }
        .s { color: var(--s); }
        .c { color: var(--c); font-style: italic; }
        .t { color: var(--t); }
        .m { color: var(--m); }
        .n { color: var(--n); }

        /* ---------- Tables ---------- */

        .table-wrap { overflow-x: auto; border: 1px solid var(--border); border-radius: var(--radius); margin: 12px 0 20px; }
        table { width: 100%; border-collapse: collapse; font-size: 13.5px; }
        thead th {
          text-align: left;
          padding: 10px 14px;
          font-weight: 600;
          font-size: 12px;
          letter-spacing: .03em;
          text-transform: uppercase;
          color: var(--muted-foreground);
          background: var(--muted);
          border-bottom: 1px solid var(--border);
          white-space: nowrap;
        }
        tbody td { padding: 10px 14px; border-bottom: 1px solid var(--border); vertical-align: top; }
        tbody tr:last-child td { border-bottom: none; }
        td .type { color: var(--m); }

        /* ---------- Cards ---------- */

        .card-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
          gap: 12px;
          margin: 12px 0 8px;
        }
        .component-card {
          display: flex;
          flex-direction: column;
          gap: 4px;
          padding: 14px 16px;
          border: 1px solid var(--border);
          border-radius: var(--radius);
          background: var(--card);
          text-decoration: none;
          transition: background .12s ease, transform .12s ease;
        }
        .component-card:hover { background: var(--accent); transform: translateY(-1px); }
        .component-card__title { font-weight: 580; font-size: 14.5px; }
        .component-card__summary { font-size: 12.5px; color: var(--muted-foreground); line-height: 1.45; }

        .notes { color: var(--muted-foreground); padding-left: 20px; }
        .notes li { margin-bottom: 6px; }

        .footer {
          margin-top: 64px;
          padding-top: 20px;
          border-top: 1px solid var(--border);
          font-size: 12.5px;
          color: var(--muted-foreground);
        }

        @media (max-width: 900px) {
          .shell { grid-template-columns: 1fr; }
          .nav { position: static; height: auto; border-right: none; border-bottom: 1px solid var(--border); }
          .main { padding: 32px 20px 64px; }
          h1 { font-size: 30px; }
        }
        """
    }

    var javascript: String {
        """
        (function () {
          const KEY = "shadswift-docs-theme";
          const root = document.documentElement;

          function apply(theme) {
            root.setAttribute("data-theme", theme);
            document.querySelectorAll(".preview__img").forEach(function (img) {
              const next = theme === "dark" ? img.dataset.dark : img.dataset.light;
              if (next && img.getAttribute("src") !== next) img.setAttribute("src", next);
            });
            document.querySelectorAll(".theme-toggle__label").forEach(function (label) {
              label.textContent = theme === "dark" ? "Light appearance" : "Dark appearance";
            });
          }

          let stored = null;
          try { stored = localStorage.getItem(KEY); } catch (e) {}
          const system = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
          apply(stored || system);

          document.querySelectorAll("[data-theme-toggle]").forEach(function (button) {
            button.addEventListener("click", function () {
              const next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
              apply(next);
              try { localStorage.setItem(KEY, next); } catch (e) {}
            });
          });

          document.querySelectorAll("[data-copy]").forEach(function (button) {
            button.addEventListener("click", function () {
              const code = button.parentElement.querySelector("code");
              if (!code) return;
              navigator.clipboard.writeText(code.innerText).then(function () {
                const previous = button.textContent;
                button.textContent = "Copied";
                setTimeout(function () { button.textContent = previous; }, 1200);
              });
            });
          });
        })();
        """
    }
}
