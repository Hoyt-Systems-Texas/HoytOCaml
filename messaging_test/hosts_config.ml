open! Core 
let hosts = [
    {
        Hoyt_messaging.Host_manager.Host_entry.host_id=1l;
        service_id=Some 1l;
        name="Test Service 1";
        sub_socket="tcp://localhost:5001";
        push_socket="tcp://localhost:5002";
        pull_socket="tcp://localhost:4000";
    };
    {
        host_id=2l;
        service_id=Some 2l;
        name="Test Service 2";
        sub_socket="tcp://localhost:5003";
        push_socket="tcp://localhost:5004";
        pull_socket="tcp://localhost:4001";
    };
    {
        host_id=(-1l);
        service_id=None;
        name="Web 1";
        sub_socket="tcp://localhost:3000";
        push_socket="tcp://localhost:3001";
        pull_socket="tcp://localhost:4002";
    };
]

let router = [
    {
        Hoyt_messaging.Host_manager.Router_entry.router_id = 100l;
        name="test Rhoouter";
        push_socket="tcp://localhost:6000"
    }
]

let create_host_manager host_id =
    Hoyt_messaging.Host_manager.make host_id
    |> Hoyt_messaging.Host_manager.load hosts
    |> Hoyt_messaging.Host_manager.load_router router