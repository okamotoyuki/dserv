/* optparse.k
 *  implementable option parser.
 *  shinpei(c)2012
 */


/* TODO,
 *  we want to write arguments dependency...
 * for example, if --b specified, we need to specify
 * all of --a, --b.
 * --a can specify independently.
 * we want to write something like that.
 *
 */


K.import("konoha");

String version = "0.0.2";

class OptionParser {
	int opts;
	Map<String, int> shortopts;
	Map<String,int> longopts;
	Func<String=>boolean>[] actions;
	String[] helps;
	String[] metavars;

	OptionParser () {
		_opts = 1;
		_shortopts = {};
		_longopts = {};
		_actions = [];
		_helps = [];
		_metavars = [];
	}

	boolean addOption (String shortopt, String longopt, Func<String=>boolean> action, String help, String metavar)
	{
		int opt_id = _opts;
		shortopts[shortopt] = opt_id;
		longopts[longopt] = opt_id;
		actions.add(action);
		helps.add(help);
		if (metavar == null) {
			metavars.add("none");
		} else {
			metavars.add(metavar);
		}
		_opts++;
		return true;
	}

	boolean check_availability(String[] args, int idx)
	{
		int argc = args.getSize();
		print idx < argc;
		if (idx < argc) {
			return true;
		}
		return false;
	}

	boolean parse (String[] args)
	{
		int argc = args.getSize();
		int parsedOpt = 0;
		int idx = 0;
		String opt_str = "";
		int opt_id;
		boolean ret = false;
		
		while (idx < argc) {
			opt_str = args[idx++];
			opt_id = shortopts[opt_str];
		
			if (opt_id == 0) {
				opt_id = longopts[opt_str];
			}

			if (opt_id != 0) {
				opt_id -= 1;
				Func<String=>boolean> parseHandler = _actions[opt_id];

				if (metavars[opt_id] != "") {
					if (!check_availability(args, idx)) {
						return false;
					}
					ret = parseHandler(args[idx++]);
				} else {
					ret = parseHandler("");
				}
			}
		}
		print ret;
		return ret;
	}

	
}

