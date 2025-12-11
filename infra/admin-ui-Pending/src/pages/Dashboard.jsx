import React, { useState, useEffect } from 'react'
import { fetchRecentComments } from '../api'
import CommentList from '../components/CommentList'

export default function Dashboard() {
  const [comments, setComments] = useState([])
  useEffect(() => {
    fetchRecentComments().then(setComments)
  }, [])
  return (
    <div>
      <h1>Site Admin Dashboard</h1>
      <h2>Recent Comments</h2>
      <CommentList comments={comments} />
    </div>
  )
}

