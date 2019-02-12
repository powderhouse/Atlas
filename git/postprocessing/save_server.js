const server = require('server');
const { post } = server.router;

server({ port: 1111, security: { csrf: false } }, [
  post('/save', ctx => {
    const html = ctx.body.html
    return 200
  })
])
