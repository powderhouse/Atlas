const server = require('server');
const { get, post } = server.router;

// Launch server with options and a couple of routes
server({ port: 1111, security: { csrf: false } }, [
  // get('/', ctx => {
  //   console.log("YO")
  //   return 'Hello world'
  // }),

  post('/save', ctx => {
    const mhtml = ctx.files.mhtml

    return 200
  })
])
