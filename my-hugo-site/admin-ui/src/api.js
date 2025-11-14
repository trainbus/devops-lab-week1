import axios from 'axios'

const API_BASE = '/api'  // update if deploying separately

export const fetchWikiPage = (slug) =>
	  axios.get(`${API_BASE}/kb/${slug}`).then(res => res.data)

export const saveWikiPage = (slug, content) =>
	  axios.put(`${API_BASE}/kb/${slug}`, { content }).then(res => res.data)

export const fetchRecentComments = () =>
	  axios.get(`${API_BASE}/comments/recent`).then(res => res.data)

