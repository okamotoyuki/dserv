/* optparse.k
 *  implementable option parser.
 *  shinpei(c)2012
 */

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
		int parsedOpt = 0;
		int idx = 0;
		String first = args[idx++];
		int opt_id = shortopts[first];
		boolean ret = false;
		if (opt_id == 0) {
			opt_id = longopts[first];
		}

		if (opt_id != 0) {
			opt_id -= 1;
			f = _actions[0];
			parseHandler = _actions[opt_id];

			if (metavars[opt_id] != "") {
				if (!check_availability(args, idx)) {
					return false;
				}
				ret = parseHandler(args[idx++]);
			} else {
				ret = parseHandler("");
			}
		}
		print ret;
		return ret;
	}

	
}

