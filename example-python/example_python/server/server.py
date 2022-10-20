import os
import os.path

from perspective import PerspectiveTornadoHandler
from tornado.web import Application, StaticFileHandler


class DebugStaticFileHandler(StaticFileHandler):
    def set_extra_headers(self, path):
        self.set_header("Cache-control", "no-cache")


def build_application(table_manager):
    handlers = [
        (
            r"/websocket",
            PerspectiveTornadoHandler,
            {"manager": table_manager, "check_origin": True},
        ),
        (
            r"/(.*)",
            DebugStaticFileHandler,
            {
                "path": os.path.join(os.path.dirname(__file__), "static"),
                "default_filename": "index.html",
            },
        ),
    ]
    application = Application(handlers, serve_traceback=True)
    return application
