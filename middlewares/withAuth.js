const { send } = require('micro');
const jwt = require('jsonwebtoken');

module.exports = fn => async (req, res) => {
    const authHeader = req.headers.authorization;
    console.log(authHeader);
    if (authHeader) {
        const token = authHeader.split(' ')[1];
        console.log(token);
        try {
            const user = jwt.verify(token, process.env.JWT_SECRET);
            req.user = user;
            return await fn(req, res);
        } catch (err) {
            console.log(err);
            send(res, 403, 'Invalid token');
        }
    } else {
        send(res, 401, 'Authorization header missing');
    }
};