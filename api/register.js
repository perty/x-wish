import { sql } from '@vercel/postgres';
import bcrypt from 'bcrypt';

export default async function handler(request, response) {
    if (request.method !== 'POST') {
        return response.status(405).json({ error: 'Method not allowed' });
    }

    const { username, password } = request.body;

    const hashedPassword = await bcrypt.hash(password, 10);

    try {
        await sql`
            INSERT INTO users (username, password)
            VALUES (${username}, ${hashedPassword})
        `;

        response.status(201).send();
    } catch (error) {
        response.status(500).json({ error: 'Database error' });
    }
}