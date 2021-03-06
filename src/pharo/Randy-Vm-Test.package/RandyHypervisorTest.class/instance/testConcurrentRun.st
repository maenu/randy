tests
testConcurrentRun
	| running proceed finished string result pool |
	running := Semaphore new.
	proceed := Semaphore new.
	finished := Semaphore new.
	string := #string.
	result := #result.
	(RandyVm stub image: Any port: Any)
		will: [ :image0 :port0 | 
			| mock |
			mock := Mock new.
			mock stub port willReturn: port0.
			(mock stub run: string)
				will: [ running signal.
					proceed wait.
					result ].
			mock ].
	hypervisor start.
	[ (hypervisor run: string) should equal: result.
	finished signal ] fork.
	running wait.
	[ (hypervisor run: string) should equal: result.
	finished signal ] fork.
	running wait.
	pool := hypervisor instVarNamed: #pool.
	pool size should equal: hot + 1.
	(pool
		count: [ :vmContainer | 
			| vm |
			vm := vmContainer instVarNamed: #vm.
			[ vm should receive start.
			vm should not receive stop.
			vm should receive run: string.
			vmContainer state should equal: #running.
			true ] ifError: [ false ] ]) should equal: 2.
	(pool
		count: [ :vmContainer | 
			| vm |
			vm := vmContainer instVarNamed: #vm.
			[ vm should receive start.
			vm should not receive stop.
			vm should not receive run: string.
			vmContainer state should equal: #ready.
			true ] ifError: [ false ] ]) should equal: 1.
	proceed signal.
	finished wait.
	(pool
		count: [ :vmContainer | 
			| vm |
			vm := vmContainer instVarNamed: #vm.
			[ vm should receive start.
			vm should not receive stop.
			vm should receive run: string.
			vmContainer state should equal: #ready.
			true ] ifError: [ false ] ]) should equal: 1.
	(pool
		count: [ :vmContainer | 
			| vm |
			vm := vmContainer instVarNamed: #vm.
			[ vm should receive start.
			vm should not receive stop.
			vm should receive run: string.
			vmContainer state should equal: #running.
			true ] ifError: [ false ] ]) should equal: 1.
	(pool
		count: [ :vmContainer | 
			| vm |
			vm := vmContainer instVarNamed: #vm.
			[ vm should receive start.
			vm should not receive stop.
			vm should not receive run: string.
			vmContainer state should equal: #ready.
			true ] ifError: [ false ] ]) should equal: 1.
	proceed signal.
	finished wait.
	(pool
		count: [ :vmContainer | 
			| vm |
			vm := vmContainer instVarNamed: #vm.
			[ vm should receive start.
			vm should not receive stop.
			vm should receive run: string.
			vmContainer state should equal: #ready.
			true ] ifError: [ false ] ]) should equal: 2.
	(pool
		count: [ :vmContainer | 
			| vm |
			vm := vmContainer instVarNamed: #vm.
			[ vm should receive start.
			vm should not receive stop.
			vm should not receive run: string.
			vmContainer state should equal: #ready.
			true ] ifError: [ false ] ]) should equal: 1.
	running isEmpty should be: true.
	proceed isEmpty should be: true.
	finished isEmpty should be: true