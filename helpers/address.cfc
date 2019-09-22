/**
* lobcfc
* Copyright 2019  Matthew J. Clemente, John Berquist
* Licensed under MIT (https://mit-license.org)
*/
component accessors="true" {

  property name="description" default="";
  property name="name" default="";
  property name="company" default="";
  property name="address_line1" default="";
  property name="address_line2" default="";
  property name="address_city" default="";
  property name="address_state" default="";
  property name="address_zip" default="";
  property name="address_country" default="";
  property name="phone" default="";
  property name="email" default="";
  property name="metadata" default="";

  /**
  * https://lob.com/docs#addresses_object
  * @hint No parameters can be passed to init this component. They must be built manually. When creating and updating addresses, the following fields are required:
    * name or company (both can be provided)
    * address_line1
    * address_city (if in US)
    * address_zip (if in US)
  */
  public any function init() {
    setMetadata( {} );
    return this;
  }

  /**
  * @hint An internal description that identifies this resource.
  */
  public any function description( required string description ) {
    setDescription( description );
    return this;
  }

  /**
  * @hint Either name or company is required
  */
  public any function name( required string name ) {
    setName( name );
    return this;
  }

  /**
  * @hint Either name or company is required
  */
  public any function company( required string company ) {
    setCompany( company );
    return this;
  }

  /**
  * @hint Required
  */
  public any function addressLine1( required string address ) {
    setAddress_line1( address );
    return this;
  }

  /**
  * @hint alias for setting address line 1
  */
  public any function address( required string address ) {
    return addressLine1( address );
  }

  public any function addressLine2( required string address ) {
    setAddress_line2( address );
    return this;
  }

  /**
  * @hint alias for setting address line 2
  */
  public any function address2( required string address ) {
    return addressLine2( address );
  }

  /**
  * @hint Required if address is in US
  */
  public any function city( required string city ) {
    setAddress_city( city );
    return this;
  }

  /**
  * @hint alias for setting city
  */
  public any function addressCity( required string city ) {
    return city( city );
  }

  /**
  * @hint Required if address is in US. Can accept either a 2 letter state short-name code or a valid full state name
  */
  public any function state( required string state ) {
    setAddress_state( state );
    return this;
  }

  /**
  * @hint alias for setting state
  */
  public any function addressState( required string state ) {
    return state( state );
  }

  /**
  * @hint Required if address is in US. Can accept either a ZIP format of 12345 or ZIP+4 format of 12345-1234
  */
  public any function zip( required string zip ) {
    setAddress_zip( zip );
    return this;
  }

  /**
  * @hint alias for setting zip
  */
  public any function addressZip( required string zip ) {
    return zip( zip );
  }

  /**
  * @hint 2 letter country short-name code (ISO 3166). Defaults to US.
  */
  public any function country( required string country ) {
    setAddress_country( country );
    return this;
  }

  /**
  * @hint alias for setting country
  */
  public any function addressCountry( required string country ) {
    return country( country );
  }

  public any function phone( required string phone ) {
    setPhone( phone );
    return this;
  }

  public any function email( required string email ) {
    setEmail( email );
    return this;
  }

  /**
  * @hint Use metadata to store custom information for tagging and labeling back to your internal systems. Must be an object with up to 20 key-value pairs. Keys must at most 40 characters and values must be at most 500 characters. Neither can contain the characters " and \. Nested objects are not supported. See https://lob.com/docs#metadata for more information.
  * @metadata if a struct is provided, it will be serialized. Otherwise the string will be set as provided
  */
  public any function metadata( required any metadata ) {
    if ( isStruct( metadata ) )
      setMetadata( serializeJSON( metadata ) );
    else
      setMetadata( metadata );
    return this;
  }

  /**
  * @hint The zip code needs to be handled via a custom method, to force it to be passed as a string
  */
  public string function build() {

    var body = '';
    var properties = getPropertyValues();
    var count = properties.len();

    properties.each(
      function( property, index ) {

        var value = property.key != 'address_zip' ? serializeJSON( property.value ) : serializeValuesAsString( property.value );
        body &= '"#property.key#": ' & value & '#index NEQ count ? "," : ""#';
      }
    );

    return '{' & body & '}';
  }

  /**
  * @hint helper that forces object value serialization to strings. This is needed in some cases, where CF's loose typing causes problems
  */
  private string function serializeValuesAsString( required any data ) {
    var result = '';
    if ( isStruct( data ) ) {
      var serializedData = data.reduce(
        function( result, key, value ) {

          if ( result.len() ) result &= ',';

          return result & '"#key#": "#value#"';
        }, ''
      );
      result = '{' & serializedData & '}';
    } else if ( isNumeric( data ) ) {
      result = '"#data#"';
    } else if ( isArray( data ) ) {
      var serializedData = data.reduce(
        function( result, item, index ) {
          if ( result.len() ) result &= ',';

          return result & '"#item#"';
        }, ''
      );

      result = '[' & serializedData & ']';
    }

    return result;
  }

  /**
  * @hint converts the array of properties to an array of their keys/values, while filtering those that have not been set
  */
  private array function getPropertyValues() {

    var propertyValues = getProperties().map(
      function( item, index ) {
        return {
          "key" : item.name,
          "value" : getPropertyValue( item.name )
        };
      }
    );

    return propertyValues.filter(
      function( item, index ) {
        if ( isStruct( item.value ) )
          return !item.value.isEmpty();
        else
          return item.value.len();
      }
    );
  }

  private array function getProperties() {

    var metaData = getMetaData( this );
    var properties = [];

    for( var prop in metaData.properties ) {
      properties.append( prop );
    }

    return properties;
  }

  private any function getPropertyValue( string key ){
    var method = this["get#key#"];
    var value = method();
    return value;
  }
}