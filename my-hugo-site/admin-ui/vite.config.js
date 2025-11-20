import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
	  plugins: [react()],
	  base: '/admin/',       // If served as static subdir in Hugo's /static/admin
	  build: {
		      outDir: '../static/admin',
		      emptyOutDir: true
		    }
})

