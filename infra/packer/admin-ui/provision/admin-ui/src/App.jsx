import React from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Dashboard from './pages/Dashboard'
import WikiEditor from './pages/WikiEditor'

export default function App() {
  return (
    <BrowserRouter basename="/admin">
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/kb/:slug" element={<WikiEditor />} />
      </Routes>
    </BrowserRouter>
  )
}

