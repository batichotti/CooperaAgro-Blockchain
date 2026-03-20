/*
  SPDX-License-Identifier: Apache-2.0
*/

import {Object, Property} from 'fabric-contract-api';

@Object()
export class Mrv {
    @Property()
    public produtor: string = '';

    @Property()
    public producao: string = '';

    @Property()
    public timestamp: string = '';

    @Property()
    public geolocalizacao: {
        lat: number;
        long: number;
    } = { lat: 0, long: 0 };

    @Property()
    public evidencia_visual: string = '';
}
