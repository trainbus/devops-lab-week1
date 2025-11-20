import React, { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'
import { fetchWikiPage, saveWikiPage } from '../api'
import MarkdownEditor from '../components/MarkdownEditor'

export default function WikiEditor() {
  const { slug } = useParams()
  const [content, setContent] = useState('')
  useEffect(() => {
    fetchWikiPage(slug).then(data => setContent(data.content))
  }, [slug])
  const handleSave = () => {
    saveWikiPage(slug, content).then(() => alert('Saved!'))
  }
  return (
    <div>
      <h1>Edit: {slug}</h1>
      <MarkdownEditor value={content} onChange={setContent} />
      <button onClick={handleSave}>Save</button>
    </div>
  )
}

