import terser from '@rollup/plugin-terser';

export default {
  input: 'main.js',
  output: {
    dir: 'output',
    format: 'iife',
  },
  plugins: [terser({
    output: { quote_style: 1 },
    compress: true
  })]
};
