# Services

Dashboard rendering is a read. `RecordingStudioDashboard::Composer` builds the layout. It does not inherit `RecordingStudio::Services::BaseService`.

Write commands in a host or another addon should use `RecordingStudio::Services::BaseService` from Recording Studio. Do not copy that class into this gem.

This gem does not ship a sample service object.
