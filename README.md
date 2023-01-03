KPImonxApp

===========================


This repository contains the source for the RIC KPI monitoring application.

This xApp can be deploy through dms_cli. Below are the steps:
1. Build Docker image
2. Onboard xApp via dms_cli
3. Deploy xApp via dms_cli
4. Register xApp to RIC platform

Modification is based on osc ric-app-kpimon-go commit Merge "Adding code files"  https://github.com/o-ran-sc/ric-app-kpimon-go

## Fix build image bug by K. D.

Bug : COPY failed: no source files were specified
See Dockerfile

## Writing InfluxDB by K. D.

- Write Data in UE Metrics to InfluxDB

### Why

It is wrong to write JSON data to InfluxDB directly, 
(I think OSC has left the coding space for us to write InfluxDB according to the data we need to use.)

Official Documentation describe what kind of type of key & value we can use in InfluxDB v1.8 we're using in the E-Release Platform.
    
- Ref : https://docs.influxdata.com/influxdb/v1.8/write_protocols/line_protocol_reference/

    - Field keys  only allows strings,
    - and Field values allows floats, integers, strings, or Booleans,
    - so we can shall the source code according to the protocol.

### Quick start

Below are all using the souce code from osc ric-app-kpimon-go commit Merge "Adding code files" 

```go
// Define data in types.go
type UeMetricsEntry struct {
	UeID                   int64        `json:"UEID"`
}
```

```go
// Assign it as data parsed from ric indication message in func handleIndication in control.go 
func (c *Control) handleIndication(params *xapp.RMRParams) (err error) {

    // some code here ....


    ueMetrics.UeID = ueID

    // some code here ....
}
```

```go
// Write InfluxDB in func writeUeMetrics_db in control.go
func (c *Control) writeUeMetrics_db(ueMetrics UeMetricsEntry) {


    // some code here ....

	p := influxdb2.NewPointWithMeasurement("ricIndication_UeMetrics").
		AddField("UEID", ueMetrics.UeID).
		SetTime(time.Now())
	writeAPI.WritePoint(context.Background(), p)

    
    // some code here ....
}
```
