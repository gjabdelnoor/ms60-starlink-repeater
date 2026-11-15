# Native Starlink mesh findings

Native adoption was investigated separately from the successful wireless repeater configuration. Ordinary read-only gRPC operations and an empty mesh stream were used. No trust writes, enrollment messages, forged credentials, or authentication-bypass attempts were sent.

| Observation | Result |
| --- | --- |
| Live router | Starlink hardware `v3`, software `2026.10.28.mr89485.1` |
| Live API version | `135` |
| Normal management endpoint | Router LAN gateway, TCP 9000 |
| Mesh call on management endpoint | `UNIMPLEMENTED: unknown service SpaceX.API.Device.Mesh` |
| Separate mesh endpoint | Router LAN gateway, TLS TCP 9002, ALPN `h2` |
| Reflected service on TLS endpoint | `SpaceX.API.Device.Mesh` |
| Method | `/SpaceX.API.Device.Mesh/MeshStream` |

The empty stream, without a client certificate, returned:

```text
PERMISSION_DENIED
Mesh node has invalid STSAFE (0): Unable to verify connected peer: Error parsing cert: x509: malformed certificate
```

The server certificate's issuer was `CN=SpaceX Router CA`. Its unique subject and the certificate itself are not included in this repository.

This demonstrates peer-certificate validation on the actual mesh service. An accepted device identity was not available for these MS60s. It does not prove every conceivable integration impossible, establish the full enrollment protocol, or show that a configured trust entry would replace the certificate requirement. No native adoption was achieved.

Public protocol definitions describe mesh join, status, configuration, steering, and backhaul messages. A full compatible agent would also need to implement those behaviors using appropriate radio/driver interfaces; listing message names or sharing an SSID does not implement that agent.

References:

- [Public mesh protocol definitions](https://github.com/clarkzjw/starlink-grpc-golang/blob/master/proto/spacex_api/device/wifi.proto)
- [Public Wi-Fi configuration definitions](https://github.com/clarkzjw/starlink-grpc-golang/blob/master/proto/spacex_api/device/wifi_config.proto)
- [Starlink Router 3 specifications](https://www.starlink.com/public-files/specification_sheet_standard.pdf)

Public descriptions of this project should call the working devices wireless repeaters or extenders, with observed client-driven roaming.
