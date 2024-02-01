// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package simple_test_netapp

import (
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestSimpleNetApp(t *testing.T) {
	netapp := tft.NewTFBlueprintTest(t)

	netapp.DefineVerify(func(assert *assert.Assertions) {
		// netapp.DefaultVerify(assert)

		projectID := netapp.GetStringOutput("project_id")
		location := netapp.GetStringOutput("location")
		// storagePool : netapp.GetStringOutput("storage_pool")
		storagePoolName := netapp.GetStringOutput("storage_pool_name")
		storagePoolID := netapp.GetStringOutput("storage_pool_id")
		volume1Name := netapp.GetStringOutput("storage_volume1_name")
		volume1ID := netapp.GetStringOutput("storage_volume1_id")
		volume2Name := netapp.GetStringOutput("storage_volume2_name")
		volume2ID := netapp.GetStringOutput("storage_volume2_id")
		volume3Name := netapp.GetStringOutput("storage_volume3_name")
		volume3ID := netapp.GetStringOutput("storage_volume3_id")

		sp := gcloud.Runf(t, "netapp storage-pools describe %s --location %s --project %s", storagePoolName, location, projectID)

		assert.Equal("2048", sp.Get("capacityGib").String(), "has expected capacityGib")
		assert.Equal("test pool", sp.Get("description").String(), "has expected description")
		assert.Equal(storagePoolID, sp.Get("name").String(), "has expected name")
		assert.Equal("PREMIUM", sp.Get("serviceLevel").String(), "has expected serviceLevel")

		sv1 := gcloud.Runf(t, "netapp volumes describe %s --location %s --project %s", volume1Name, location, projectID)

		assert.Equal("100", sv1.Get("capacityGib").String(), "has expected capacityGib")
		assert.Equal("UNIX", sv1.Get("securityStyle").String(), "has expected securityStyle")
		assert.Equal(volume1ID, sv1.Get("name").String(), "has expected name")
		assert.Equal("PREMIUM", sv1.Get("serviceLevel").String(), "has expected serviceLevel")
		assert.Equal("1", sv1.Get("snapshotPolicy.dailySchedule.snapshotsToKeep").String(), "has expected snapshotsToKeep")
		assert.Equal("23", sv1.Get("snapshotPolicy.dailySchedule.hour").String(), "has expected hour")
		assert.Equal("45", sv1.Get("snapshotPolicy.dailySchedule.minute").String(), "has expected minute")

		sv2 := gcloud.Runf(t, "netapp volumes describe %s --location %s --project %s", volume2Name, location, projectID)

		assert.Equal("200", sv2.Get("capacityGib").String(), "has expected capacityGib")
		assert.Equal("UNIX", sv2.Get("securityStyle").String(), "has expected securityStyle")
		assert.Equal(volume2ID, sv2.Get("name").String(), "has expected name")
		assert.Equal("PREMIUM", sv2.Get("serviceLevel").String(), "has expected serviceLevel")
		assert.Equal("1", sv2.Get("snapshotPolicy.dailySchedule.snapshotsToKeep").String(), "has expected snapshotsToKeep")
		assert.Equal("22", sv2.Get("snapshotPolicy.dailySchedule.hour").String(), "has expected hour")
		assert.Equal("0", sv2.Get("snapshotPolicy.dailySchedule.minute").String(), "has expected minute")

		sv3 := gcloud.Runf(t, "netapp volumes describe %s --location %s --project %s", volume3Name, location, projectID)

		assert.Equal("100", sv3.Get("capacityGib").String(), "has expected capacityGib")
		assert.Equal("UNIX", sv3.Get("securityStyle").String(), "has expected securityStyle")
		assert.Equal(volume3ID, sv3.Get("name").String(), "has expected name")
		assert.Equal("PREMIUM", sv3.Get("serviceLevel").String(), "has expected serviceLevel")
		assert.Equal("1", sv3.Get("snapshotPolicy.dailySchedule.snapshotsToKeep").String(), "has expected snapshotsToKeep")
		assert.Equal("21", sv3.Get("snapshotPolicy.dailySchedule.hour").String(), "has expected hour")
		assert.Equal("21", sv3.Get("snapshotPolicy.dailySchedule.minute").String(), "has expected minute")
		assert.Equal("1", sv3.Get("snapshotPolicy.weeklySchedule.snapshotsToKeep").String(), "has expected snapshotsToKeep")
		assert.Equal("1", sv3.Get("snapshotPolicy.weeklySchedule.hour").String(), "has expected hour")
		assert.Equal("1", sv3.Get("snapshotPolicy.weeklySchedule.minute").String(), "has expected minute")
		assert.Equal("Monday", sv3.Get("snapshotPolicy.weeklySchedule.day").String(), "has expected day")

	})
	netapp.Test()
}
