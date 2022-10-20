from perspective import PerspectiveManager


def get_tables():
    return {}


def get_table_manager():
    manager = PerspectiveManager()
    for name, table in get_tables().items():
        manager.host_table(name, table)
    return manager
