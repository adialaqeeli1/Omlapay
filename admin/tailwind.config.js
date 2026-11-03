import plugin from 'tailwindcss/plugin'

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#2BA39B',
          light: '#2AA29A24',
          main: '#2AA29A',
        },
        dark: {
          DEFAULT: '#111111',
          main: '#131414',
          light: '#1B1D1D',
          lighter: '#9D9D9D3D',
        },
        light: {
          DEFAULT: '#C1C1C1',
          active: '#FCFFFF',
          main: '#E5FFFD',
          secondary: '#9A9A9A',
        },
        warning: {
          DEFAULT: '#FFC107',
        },
        danger: {
          DEFAULT: '#F92A2A',
          light: '#F92A2A1F',
        },
      },
      borderColor: {
        main: '#1C1F1E',
        'primary-dark': '#2BA39B',
      },
      boxShadow: {
        primary1: '0px 12px 28px 0px #0000004D',
      },
    },
  },
  plugins: [
    plugin(function ({ addVariant }) {
      addVariant('data-checked', '&[data-checked]')
      addVariant('group-data-checked', ':merge(.group)[data-checked] &')
    }),
  ],
}
