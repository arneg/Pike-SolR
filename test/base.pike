constant arg_options = ({
    ({ "host", Getopt.HAS_ARG, "-s" }),
    ({ "port", Getopt.HAS_ARG, "-p" }),
    ({ "core", Getopt.HAS_ARG, "-c" }),
});

void terminate() {
    exit(0);
}

void default_get_cb(int(0..1) ok, mixed result) {
    if (!ok) {
        write("ERROR: %O\n", result);
    } else write(">> %O\n", result);
}

int main(int argc, array(string) argv) {
    array tmp = Getopt.find_all_options(argv, arg_options, 1);
    mapping options = mkmapping(tmp[*][0], tmp[*][1]);

    options->port = (int)options->port;

    argv = Getopt.get_args(argv, 1)[1..];

    SolR.Instance solr = SolR.Instance(options->host, options->port);
    SolR.Collection core = solr->collection(options->core);

    signal(signum("SIGTERM"), terminate);
    signal(signum("SIGINT"), terminate);

    solr->admin->list_collections(lambda(int ok, mixed collections) {
        if (ok) foreach (collections;; string name) {
            solr->collection(name)->schema->retrieve(default_get_cb);
        }
    });

    switch (sizeof(argv) && argv[-1]) {
    case "schema":
        core->schema->retrieve(default_get_cb);
    }

    return -1;
}
