import { sql } from '@vercel/postgres';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

export default async function handler(request, response) {
    if (request.method !== 'POST') {
        return response.status(405).json({ error: 'Method not allowed' });
    }

    const { username, password } = request.body;

    try {
        const userResult = await sql`
            SELECT * FROM users WHERE username = ${username}
        `;

        if (userResult.rows.length === 0) {
            return response.status(400).json({ error: 'User not found' });
        }

        const user = userResult.rows[0];

        if (await bcrypt.compare(password, user.password)) {
            const token = jwt.sign({ id: user.id, username: user.username }, process.env.JWT_SECRET);
            response.json({ token });
        } else {
            response.status(403).json({ error: 'Invalid password' });
        }
    } catch (error) {
        console.error(error);
        response.status(500).json({ error: 'Database error' });
    }
}