#!/bin/sh

swiftgen xcassets --templatePath "templates/xcassets.stencil" --param enumName=GLAssets --output "../leadsbooster/Global/XCAssets.swift" ../leadsbooster/Resources/Assets.xcassets
