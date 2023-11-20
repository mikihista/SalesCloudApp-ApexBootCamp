import { LightningElement, api} from 'lwc';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import addTopSellingProducts from '@salesforce/apex/AddBestSellerButtonController.addTopSellingProducts';

export default class Top5BestSellerButton extends LightningElement {

    @api recordId;

    @api
    async invoke() {
        let params = {
            "oppId": this.recordId
        };

        addTopSellingProducts(params).then(result => {
                this.dispatchEvent(new RefreshEvent());
                console.log('Got Result from Randmozation: ', JSON.parse(JSON.stringify(result)));
                notifyRecordUpdateAvailable([{recordId: this.recordId}]);
            }
        ).catch(error => {
            console.log('Got ERROR from Randomization: ', JSON.parse(JSON.stringify(error)))
        }
        );
    }
}