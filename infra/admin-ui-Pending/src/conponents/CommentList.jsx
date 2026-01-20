import React from 'react'
export default function CommentList({ comments }) {
  return (
    <ul>
      {comments.map(cmt => (
        <li key={cmt.id}>
          <b>{cmt.author}</b> [{cmt.date}]: {cmt.text}
        </li>
      ))}
    </ul>
  )
}

