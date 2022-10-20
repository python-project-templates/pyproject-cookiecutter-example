from tornado.ioloop import IOLoop

from .server import build_application
from .tables import get_table_manager


def main():
    table_manager = get_table_manager()
    app = build_application(table_manager)
    app.listen(8080)
    IOLoop.instance().start()


if __name__ == "__main__":
    main()
