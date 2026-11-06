"""serve.py serves the dashboard at / and the tasks dir at /tasks/ on 127.0.0.1 only."""
import os, sys, tempfile, threading, unittest, urllib.request, urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "dashboard"))
import serve  # noqa: E402


class ServeTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.mkdtemp()
        os.makedirs(os.path.join(cls.tmp, "VUNG-000011-x", "factory"))
        with open(os.path.join(cls.tmp, "VUNG-000011-x", "factory", "ticket.json"), "w") as f:
            f.write('{"key": "VUNG-000011"}')
        cls.server = serve.make_server(0, cls.tmp)
        cls.port = cls.server.server_address[1]
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()

    def get(self, path):
        return urllib.request.urlopen("http://127.0.0.1:%d%s" % (self.port, path)).read().decode()

    def test_binds_loopback(self):
        self.assertEqual(self.server.server_address[0], "127.0.0.1")

    def test_dashboard_root(self):
        self.assertIn("ngvu-factory", self.get("/"))

    def test_tasks_listing_and_file(self):
        self.assertIn("VUNG-000011-x/", self.get("/tasks/"))
        self.assertIn("VUNG-000011", self.get("/tasks/VUNG-000011-x/factory/ticket.json"))

    def test_no_escape_from_tasks(self):
        with self.assertRaises(urllib.error.HTTPError):
            self.get("/tasks/..%2f..%2f..%2fWindows/win.ini")


if __name__ == "__main__":
    unittest.main()
