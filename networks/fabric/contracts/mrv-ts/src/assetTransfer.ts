/*
 * SPDX-License-Identifier: Apache-2.0
 */
import {Context, Contract, Info, Returns, Transaction} from 'fabric-contract-api';
import stringify from 'json-stringify-deterministic';
import sortKeysRecursive from 'sort-keys-recursive';
import {Mrv} from './asset';

@Info({title: 'MrvTransfer', description: 'Smart contract for MRV assets'})
export class AssetTransferContract extends Contract {

    @Transaction()
    public async InitLedger(ctx: Context): Promise<void> {
        const assets: Mrv[] = [
            {
                produtor: 'Produtor1',
                producao: 'Soja',
                timestamp: '2024-01-01T10:00:00Z',
                geolocalizacao: { lat: -15.5, long: -48.5 },
                evidencia_visual: 'bafybeifh54tx4yu6jzsqskersfc2jcinpap35pruz6q5eg36lbtq2u65y4',
            },
        ];

        for (const asset of assets) {
            await ctx.stub.putState(asset.produtor, Buffer.from(stringify(sortKeysRecursive(asset))));
            console.info(`MRV ${asset.produtor} initialized`);
        }
    }

    @Transaction()
    public async CreateAsset(ctx: Context, produtor: string, producao: string, timestamp: string, lat: number, long: number, evidencia_visual: string): Promise<void> {
        const exists = await this.AssetExists(ctx, produtor);
        if (exists) {
            throw new Error(`MRV ${produtor} already exists`);
        }

        const asset: Mrv = {
            produtor,
            producao,
            timestamp,
            geolocalizacao: { lat, long },
            evidencia_visual,
        };
        await ctx.stub.putState(produtor, Buffer.from(stringify(sortKeysRecursive(asset))));
    }

    @Transaction(false)
    public async ReadAsset(ctx: Context, produtor: string): Promise<string> {
        const assetJSON = await ctx.stub.getState(produtor);
        if (assetJSON.length === 0) {
            throw new Error(`MRV ${produtor} does not exist`);
        }
        return assetJSON.toString();
    }

    @Transaction()
    public async UpdateAsset(ctx: Context, produtor: string, producao: string, timestamp: string, lat: number, long: number, evidencia_visual: string): Promise<void> {
        const exists = await this.AssetExists(ctx, produtor);
        if (!exists) {
            throw new Error(`MRV ${produtor} does not exist`);
        }

        const updatedAsset: Mrv = {
            produtor,
            producao,
            timestamp,
            geolocalizacao: { lat, long },
            evidencia_visual,
        };
        return ctx.stub.putState(produtor, Buffer.from(stringify(sortKeysRecursive(updatedAsset))));
    }

    @Transaction()
    public async DeleteAsset(ctx: Context, produtor: string): Promise<void> {
        const exists = await this.AssetExists(ctx, produtor);
        if (!exists) {
            throw new Error(`MRV ${produtor} does not exist`);
        }
        return ctx.stub.deleteState(produtor);
    }

    @Transaction(false)
    @Returns('boolean')
    public async AssetExists(ctx: Context, produtor: string): Promise<boolean> {
        const assetJSON = await ctx.stub.getState(produtor);
        return assetJSON.length > 0;
    }

    @Transaction(false)
    @Returns('string')
    public async GetAllAssets(ctx: Context): Promise<string> {
        const allResults = [];
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue) as Mrv;
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push(record);
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }
}
