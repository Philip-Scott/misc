public static int main (string[] args) {
	NetworkMonitor monitor = NetworkMonitor.get_default ();

	//
	// Check whether the network is considered available:
	// (network availability != internet)
	//

	bool available = monitor.get_network_available ();
	stdout.printf ("Network available: %s\n", available.to_string ());

	//
	// Recheck availability when the network configuration changes:
	//
	monitor.network_changed.connect ((available) => {
		stdout.printf ("Network changed (available: %s)\n", available.to_string ());

		// Determine if is behind a captive portal via GLib.NetworkConnectivity
		if (available == true) {
			switch (monitor.get_network_connectivity ()) {
				case NetworkConnectivity.LOCAL: stdout.printf ("LOCAL\n"); break;
				case NetworkConnectivity.LIMITED: stdout.printf ("LOCAL\n"); break;
				case NetworkConnectivity.PORTAL: stdout.printf ("LOCAL\n"); break;
				case NetworkConnectivity.FULL: stdout.printf ("LOCAL\n"); break;
			}
		}
	});

	new MainLoop ().run ();
	return 0;
}
