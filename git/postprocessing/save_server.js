const server = require('server');
const { post } = server.router;
const fs = require('fs')

server({ port: 1111, security: { csrf: false } }, [
  post('/save', ctx => {
    const html = ctx.body.html
    const title = ctx.body.title || "output"

    fs.writeFileSync(title + ".html", html);
    console.log(title + " saved...")

    return 200
  })
])
