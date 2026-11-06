"""Serve the ngvu-factory dashboard (/) and a tasks folder (/tasks/) on 127.0.0.1, read-only.

Usage: python serve.py [--port 8765] [--tasks <dir>]
--tasks defaults to paths.tasks (else workspace + /tasks) of the machine config deploy/bootstrap wrote.
"""
import argparse
import http.server
import json
import os
import posixpath
import urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))


def default_tasks():
    p = os.environ.get("KF_MACHINE_CONFIG") or os.path.expanduser("~/.claude/ngvu-factory/machine.json")
    try:
        cfg = json.load(open(p, encoding="utf-8-sig"))
    except (OSError, ValueError):
        cfg = {}
    return cfg.get("paths", {}).get("tasks") or cfg.get("workspace", "D:/workspace") + "/tasks"


class Handler(http.server.SimpleHTTPRequestHandler):
    tasks_dir = None

    def translate_path(self, path):
        path = urllib.parse.urlsplit(path).path
        if path == "/tasks" or path.startswith("/tasks/"):
            root, rel = self.tasks_dir, path[len("/tasks"):]
        else:
            root, rel = HERE, path
        parts = []
        for p in posixpath.normpath(urllib.parse.unquote(rel)).split("/"):
            if p in ("", "."):
                continue
            if p == ".." or os.sep in p or (os.altsep and os.altsep in p) or ":" in p:
                return os.path.join(root, "__forbidden__")
            parts.append(p)
        return os.path.join(root, *parts)

    def do_POST(self):
        self.send_error(405)

    def log_message(self, fmt, *args):
        pass


def make_server(port, tasks_dir):
    handler = type("BoundHandler", (Handler,), {"tasks_dir": os.path.abspath(tasks_dir)})
    return http.server.ThreadingHTTPServer(("127.0.0.1", port), handler)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=8765)
    ap.add_argument("--tasks", default=default_tasks())
    a = ap.parse_args()
    srv = make_server(a.port, a.tasks)
    print("ngvu-factory dashboard: http://127.0.0.1:%d/  (tasks: %s)" % (srv.server_address[1], a.tasks))
    srv.serve_forever()


if __name__ == "__main__":
    main()
