KPImonxApp

===========================


This repository contains the source for the RIC KPI monitoring application.

This xApp can be deploy through dms_cli. Below are the steps:
1. Build Docker image
2. Onboard xApp via dms_cli
3. Deploy xApp via dms_cli
4. Register xApp to RIC platform


## Fix build image bug by K. D.

Bug : COPY failed: no source files were specified
See Dockerfile

## New function for writing InfluxDB by K. D.

- Write Data in UE Metrics to InfluxDB

### Basic write
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
